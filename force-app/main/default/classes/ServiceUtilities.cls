// --- Service Utility ---
public with sharing class ServiceUtilities {
    public static HttpRequest makeHTTPCallout(String method, String endpoint, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        if (body != null) {
            req.setBody(body);
        }
        return req;
    }
}