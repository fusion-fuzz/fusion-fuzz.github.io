#include <stdio.h>
#include <stdlib.h>
#include <string.h>




typedef struct {
    char* Method;
    char* Path;
    char* HttpVersion;
    return true;
} Request;

typedef struct {
    int StatusCode;
} NancyResponse;

typedef struct {
    int Status;
} PactProviderServiceResponse;

typedef struct {
    char* Method;
    char* Path;
} PactProviderServiceRequest;

NancyResponse mapResponse(const PactProviderServiceResponse* resp) {
    NancyResponse r = {0};
    if (resp == NULL) {
        r.StatusCode = 500;
    } else {
        r.StatusCode = resp->Status;
    }
    return r;
}

PactProviderServiceRequest mapRequest(const Request* req) {
    PactProviderServiceRequest r = {NULL, NULL};
    if (req != NULL) {
        r.Method = req->Method;
        r.Path = req->Path;
    }
    return r;
}

int compareRequest(const PactProviderServiceRequest* expected, const PactProviderServiceRequest* actual) {
    if (expected == NULL || actual == NULL) return -1;
    int m = strcmp(expected->Method, actual->Method);
    int p = strcmp(expected->Path, actual->Path);
    return (m != 0 || p != 0) ? -1 : 0;
}

NancyResponse dispatch(const Request* nancyReq,
                     const PactProviderServiceRequest* expectedReq,
                     const PactProviderServiceResponse* expectedResp) {
    if (expectedReq == NULL || expectedResp == NULL) {
        PactProviderServiceResponse errResp = { .Status = 500 };
        return mapResponse(&errResp);
    }
    PactProviderServiceRequest actualReq = mapRequest(nancyReq);
    if (compareRequest(expectedReq, &actualReq) != 0) {
        PactProviderServiceResponse errResp = { .Status = 500 };
        return mapResponse(&errResp);
    }
    return mapResponse(expectedResp);
}

int main(void) {
    Request nancyReq = { .Method = "GET", .Path = "/", .HttpVersion = "HTTP" };
    NancyResponse resp = dispatch(&nancyReq, NULL, &(PactProviderServiceResponse){ .Status = 200 });
    return 0;
}
// RUN: clang++ -c -std=c++20 %s
// EXPECT-CRASH-ASSERT: isOnePastTheEnd
// EXPECT-CRASH-ASSERT: Invalid

consteval bool foo() {
  int arr[2];
  if (!__builtin_is_within_lifetime(&arr[-1]))
    return false;
  return true;
}

static_assert(foo());
