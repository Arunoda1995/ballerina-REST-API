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
    int cholesterolId;
    int hdl;
    

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
        path: "/cholesterol/"
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

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/cholesterol/{cholesterolId}"
    }
    retriveCholesterolData(endpoint httpConnection,http:Request request, string cholesterolId)
    {
        http:Response response;

        int choId = check <int> cholesterolId;

        var cholesterolData = getCholesterolData(choId);

        response.setJsonPayload(cholesterolData);
        _=httpConnection->respond(response);

    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/cholesterol/"
    }
    updateCholesterolData(endpoint httpConnection,http:Request request)
    {
        http:Response response;
        Cholesterol cholesterolData;

        var payLoadJson = check request.getJsonPayload();
        cholesterolData = check <Cholesterol>payLoadJson;

        if(cholesterolData.gender == "" || cholesterolData.age == 0 || cholesterolData.totalCholesterol ==0 || cholesterolData.non_hd ==0 ||
            cholesterolData.ldl == 0 || cholesterolData.hdl == 0 || cholesterolData.cholesterolId == 0
        )
        {

            response.setTextPayload("Error");
            response.statusCode = 400;
            _ = httpConnection->respond(response);
            done;

        }

        json result = updateCholData(cholesterolData.gender,cholesterolData.age,cholesterolData.totalCholesterol,cholesterolData.non_hd,cholesterolData.ldl,cholesterolData.hdl,cholesterolData.cholesterolId);
        response.setJsonPayload(result);
        _=httpConnection->respond(response);

    }
}


public function insertCholesterolData(string gender,int age,int totalCholesterol, int non_hd,int ldl,int hdl, int id) returns(json)
{

    json data;

    string sqlQuery = "INSERT INTO CHOLESTEROL(age,gender,totalCholesterol,non_hd,ldl,hdl,cholesterolId) VALUES(?,?,?,?,?,?,?)";

    var ret = cholesterolDB->update(sqlQuery,age,gender,totalCholesterol,non_hd,ldl,hdl,id);

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

public function getCholesterolData(int cholesterolId) returns(json)
{
    json data;

    string sqlQuery = "SELECT * FROM CHOLESTEROL WHERE CholesterolId = ?";

    var result = cholesterolDB->select(sqlQuery,(),cholesterolId);

    match result {

        table dataTable =>{
            data  = check <json>dataTable;
        }

        error err =>{
            data  = {"Status":"Data Not Found","Error":err.message};
        }
    }

    return data;

}

public function updateCholData(string gender,int age,int totalCholesterol, int non_hd,int ldl,int hdl, int id) returns(json)
{

    json data;

    string sqlQuery = "UPDATE CHOLESTEROL SET age = ?,gender=?,totalCholesterol=?,non_hd=?,ldl=?,hdl=? WHERE cholesterolId = ?";

    var ret = cholesterolDB->update(sqlQuery,age,gender,totalCholesterol,non_hd,ldl,hdl,id);

    match ret {
        int updateRowCount => {
            data = {"Status":"Data Update Successfully"};
        }
        error err=>{
            data = {"Status": "Data Not Updated","Error": err.message};
        }
    }

    return data;

}










