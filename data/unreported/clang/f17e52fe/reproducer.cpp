#include <math.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// RUN: clang++ -c %s
// EXPECT-CRASH-ASSERT: getVectorType
// EXPECT-CRASH-ASSERT: isBuiltinType
// EXPECT-CRASH-ASSERT: isBitIntType
// EXPECT-CRASH-ASSERT: isPowerOf2_32

using V1 = short((ext_vector_type(4)));
using V2 = short __attribute__((__vector_size__(8)));

void foo() {
            lock_free_add(&gw->weights[i][j + 2], -update);
            lock_free_add(&gw->weights[i][j + 3], update * 0.5f);
            j += VEC_SIZE;
  V1 v1;
  V2 v2;
  (v2 ? v1 : v1);
}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdatomic.h>
#include <math.h>

#define LAYER_SIZE 4
#define FEATURE_SIZE 16
#define VEC_SIZE 4
#define NUM_THREADS 4

typedef struct {
    float **weights;
    float **learning_rate;
    pthread_mutex_t *locks;
    int layer_size;
    int feature_size;
} GateWeight;

GateWeight *create_gate_weight(int layer_size, int feature_size) {
    GateWeight *gw = malloc(sizeof(GateWeight));
    gw->layer_size = layer_size;
    gw->feature_size = feature_size;
    gw->weights = malloc(layer_size * sizeof(float *));
    gw->learning_rate = malloc(layer_size * sizeof(float *));
    gw->locks = malloc(layer_size * sizeof(pthread_mutex_t));
    for (int i = 0; i < layer_size; i++) {
        gw->weights[i] = calloc(feature_size, sizeof(float));
        gw->learning_rate[i] = calloc(feature_size, sizeof(float));
        pthread_mutex_init(&gw->locks[i], NULL);
        for (int j = 0; j < feature_size; j++) {
            gw->weights[i][j] = (float)rand() / RAND_MAX * 0.01f;
        }
    }
    return gw;
}

GateWeight *clone_shared_weights(GateWeight *src) {
    GateWeight *dst = malloc(sizeof(GateWeight));
    dst->layer_size = src->layer_size;
    dst->feature_size = src->feature_size;
    dst->weights = src->weights;
    dst->learning_rate = src->learning_rate;
    dst->locks = src->locks;
    return dst;
}

void lock_free_add(float *addr, float val) {
    atomic_float *a = (atomic_float *)addr;
    float old, new_val;
    do {
        old = atomic_load(a);
        new_val = old + val;
    } while (!atomic_compare_exchange_weak(a, &old, new_val));
}

void *update_weights(void *arg) {
    GateWeight *gw = (GateWeight *)arg;
    int tid = *(int *)arg;
    float err = 0.01f * (tid + 1);
    float feature_deriv = 0.5f;
    float c_y_forget = 0.8f;

    for (int i = tid; i < gw->layer_size; i += NUM_THREADS) {
        int j = 0;
        while (j < gw->feature_size - VEC_SIZE) {
            float delta = feature_deriv * err;
            float lr = gw->learning_rate[i][j];
            lr += delta * delta;
            gw->learning_rate[i][j] = lr;
            float actual_lr = 0.01f / (sqrtf(lr) + 1.0f);
            float update = actual_lr * delta;

            pthread_mutex_lock(&gw->locks[i]);
            gw->weights[i][j] += update;
            pthread_mutex_unlock(&gw->locks[i]);

            lock_free_add(&gw->weights[i][j + 1], update);
            lock_free_add(&gw->weights[i][j + 2], -update);
            lock_free_add(&gw->weights[i][j + 3], update * 0.5f);
            j += VEC_SIZE;
        }
        while (j < gw->feature_size) {
            float delta = feature_deriv * err;
            float lr = gw->learning_rate[i][j];
            lr += delta * delta;
            gw->learning_rate[i][j] = lr;
            float actual_lr = 0.01f / (sqrtf(lr) + 1.0f);
            float update = actual_lr * delta;

            pthread_mutex_lock(&gw->locks[i]);
            gw->weights[i][j] += update;
            pthread_mutex_unlock(&gw->locks[i]);

            lock_free_add(&gw->weights[i][j], update * 0.1f);
            j++;
        }
    }
    return NULL;
}

int main() {
    srand(42);
    GateWeight *original = create_gate_weight(LAYER_SIZE, FEATURE_SIZE);
    GateWeight *cloned = clone_shared_weights(original);

    pthread_t threads[NUM_THREADS];
    int thread_ids[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[i] = i;
        pthread_create(&threads[i], NULL, update_weights, &thread_ids[i]);
    }
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    float sum = 0.0f;
    for (int i = 0; i < LAYER_SIZE; i++) {
        for (int j = 0; j < FEATURE_SIZE; j++) {
            sum += original->weights[i][j];
        }
    }
    printf("Weight sum: %f\n", sum);

    for (int i = 0; i < LAYER_SIZE; i++) {
        free(original->weights[i]);
        free(original->learning_rate[i]);
        pthread_mutex_destroy(&original->locks[i]);
    }
    free(original->weights);
    free(original->learning_rate);
    free(original->locks);
    free(original);
    free(cloned);
    return 0;
}
