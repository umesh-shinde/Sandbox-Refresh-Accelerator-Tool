@isTest
global class Mcoe_ServiceRequestSuccessMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success":true,"errors":[],"warnings":[],"infos":[]}');
        response.setStatusCode(201);
        return response;
    }
}