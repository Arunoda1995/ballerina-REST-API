import ballerina/sql;
import ballerina/mysql;
import ballerina/log;
import ballerina/http;

endpoint http:Listener listener {
    port: 9090
};
@http:ServiceConfig{
    basePath:"/developer"
}
service<http:Service> CholesterolData bind listener{
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/cholesterol"
    }
    addCholesterolData(endpoint client,http:Request req)
    {
        log:printInfo("developer/cholesterol/GET");
    }

}


@http:ServiceConfig{
    basePath:"/user"
}
service<http:Service> userData bind listener{
    @http:ResourceConfig{
        methods: ["GET"],
        path:"/cholesterol"
    }
    getCholesterolData(endpoint client,http:Request req)
    {
        log:printInfo("user/cholesterol/GET");
    }

}



