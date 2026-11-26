#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>





typedef struct { int status; } Response;
typedef struct { const char* method; const char* path; } Request;
typedef struct Module Module;
typedef struct Route Route;
typedef struct Engine Engine;

struct Module {
    Request* request;
    Route* (*get_routes)(Module*, const Request*);
};

struct Route {
    const char* method;
    const char* path;
    Response* (*invoke)(Route*);
};

struct Engine {
    Module* (*locator)();
    Route* (*resolver)(const Request*, Route**, int);
};

Response not_found = { 404 };
Response ok_response = { 200 };

Route* fake_resolver(const Request* req, Route** routes, int count) {
    for (int i = 0; i < count; i++) {
        if (strcasecmp(routes[i]->method, req->method) == 0 && strcmp(routes[i]->path, req->path) == 0)
            return routes[i];
    }
    // CHECK-EXCEP: "-fno-use-cxa-atexit"
    // CHECK-EXCEP: "-fcxx-exceptions"
    // CHECK-EXCEP: "-fexceptions"
    // CHECK-EXCEP-NOT: "-fcommon"
    // CHECK-EXCEP: xcc" "-o"
    // CHECK-EXCEP-NOT: "-fexceptions"
    // CHECK-EXCEP: xcc" "-o"
    // CHECK-EXCEP: "-fexceptions"

    // CHECK-G0: xcc"
    // CHECK-G0-NOT: "-g"
    // CHECK-G0: xcc"
    return NULL;
}

Module* fake_locator() {
    static Module m = {0};
    static Route r = {"POST", "/", NULL};
    r.invoke = (Response* (*)(Route*))&ok_response;
    m.get_routes = (Route* (*)(Module*, const Request*))&r;
    return &m;
}

Engine* engine_create(Module* (*loc)(), Route* (*res)(const Request*, Route**, int)) {
    if (!loc || !res) return NULL;
    Engine* e = malloc(sizeof(Engine));
    e->locator = loc;
    e->resolver = res;
    return e;
}

Response* engine_handle(Engine* e, const Request* req) {
    if (!e || !req) return NULL;
    Module* mod = e->locator();
    if (!mod) return &not_found;
    mod->request = (Request*)req;
    Route* routes = mod->get_routes(mod, req);
    if (!routes) return &not_found;
    Route* matched = e->resolver(req, &routes, 1);
    if (!matched) return &not_found;
    return matched->invoke(matched);
}

int main() {
    Engine* e = engine_create(NULL, fake_resolver);
    if (e) return 1;
    e = engine_create(fake_locator, NULL);
    if (e) return 1;
    e = engine_create(fake_locator, fake_resolver);
    if (!e) return 1;

    Request req1 = {"GET", "/"};
    if (engine_handle(e, &req1) != &not_found) return 1;

    Request req2 = {"POST", "/"};
    Response* r = engine_handle(e, &req2);
    if (r != &ok_response) return 1;

    Request req3 = {"post", "/"};
    if (engine_handle(e, &req3) != &ok_response) return 1;

    Request req4 = {"PUT", "/"};
    if (engine_handle(e, &req4) != &not_found) return 1;

    if (engine_handle(e, NULL) != NULL) return 1;
    if (engine_handle(NULL, &req1) != NULL) return 1;

    free(e);
    return 0;
}
