import ballerina/sql;
import ballerina/mysql;
import ballerina/log;
import ballerina/http;
import ballerina/config;


type Cholesterol {

    string gender;
    int age;
    int totalCholesterol;
    int non_hd;
    int ldl;
    int hdl;
    int cholesterolId;

};




endpoint mysql:Client cholesterolDB {
        host: config:getAsString("DATABASE_HOST", default = "localhost"),
        port: config:getAsInt("DATABASE_PORT", default = 3306),
        name: config:getAsString("DATABASE_NAME", default = "HEALTH_RECORDS"),
        username: config:getAsString("DATABASE_USERNAME",default="root"),
        password: config:getAsString("DATABASE_PASSWORD", default=""),
        dbOptions: {useSSL: false}
};


endpoint http:Listener listener {
    port: 9090
};
@http:ServiceConfig{
    basePath:"/developer"
}
service<http:Service> CholesterolData bind listener{
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/cholesterol"
    }
    addCholesterolData(endpoint httpConnection,http:Request request)
    {


        http:Response response;
        Cholesterol cholesterolData;

        var payloadJson = check request.getJsonPayload();
        cholesterolData = check <Cholesterol> payloadJson;

        if(cholesterolData.gender == "" || cholesterolData.age == 0 || cholesterolData.totalCholesterol ==0 || cholesterolData.non_hd ==0 ||
            cholesterolData.ldl == 0 || cholesterolData.hdl == 0 || cholesterolData.cholesterolId == 0
        )
        {

            response.setTextPayload("Error");
            response.statusCode = 400;
            _ = httpConnection->respond(response);
            done;

        }

        json result = insertCholesterolData(cholesterolData.gender,cholesterolData.age,cholesterolData.totalCholesterol,cholesterolData.non_hd,cholesterolData.ldl,cholesterolData.hdl,cholesterolData.cholesterolId);
        response.setJsonPayload(result);
        _=httpConnection->respond(response);
    }

}


public function insertCholesterolData(string gender,int age,int totalCholesterol, int non_hd,int ldl,int hdl, int id)
{

    json data;

    string sqlQuery = "INSERT INTO CHOLESTEROL(id,age,gender,totalCholesterol,non-hd,ldl,hdl) VALUES(?,?,?,?,?,?,?)";

    var ret = cholesterolDB->update(sqlQuery,id,age,gender,totalCholesterol,non_hd,ldl,hdl);

    match ret {
        int updateRowCount => {
            data = {"Status":"Data Inserted Successfully"};
        }
        error err=>{
            data = {"Status": "Data Not inserted","Error": err.message};
        }
    }

    return data;

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



