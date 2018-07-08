import ballerina/sql;
import ballerina/mysql;
import ballerina/log;
import ballerina/http;
import ballerina/config;
import wso2/gmail;


string accessToken = config:getAsString("ACCESS_TOKEN");
string cliendId = config:getAsString("CLIENT_ID");
string clientSecret = config:getAsString("CLIENT_SECRET");
string refreshToken = config:getAsString("REFRESH_TOKEN");
string sender = config:getAsString("SENDER");
string userId = config:getAsString("USER_ID");



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


endpoint gmail:Client gmailClient {
    clientConfig:{
        auth:{
            accessToken:accessToken,
            refreshToken:refreshToken,
            clientId:cliendId,
            clientSecret:clientSecret
        }
    }
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


    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/cholesterol/{cholesterolId}"
    }
    deleteCholesterolData(endpoint httpConnection,http:Request request, string cholesterolId)
    {
        http:Response response;

        int choId = check <int> cholesterolId;

        var cholesterolData = deleteCholData(choId);

        response.setJsonPayload(cholesterolData);
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

public function deleteCholData(int cholesterolId) returns(json)
{
    json data;

    string sqlQuery = "DELETE FROM CHOLESTEROL WHERE CholesterolId = ?";

    var result = cholesterolDB->update(sqlQuery,cholesterolId);

    match result {

        int updateRowCount =>{
            data  = {"Status":"Data Deleted Successfully"};
        }

        error err =>{
            data  = {"Status":"Data Not Deleted","Error":err.message};
        }
    }

    return data;

}


@http:ServiceConfig{
    basePath:"/user"
}
service<http:Service> userCholesterolData bind listener{


    @http:ResourceConfig {
        methods: ["POST"],
        path: "/cholesterol"
    }
    retriveCholesterolData(endpoint client,http:Request req)
    {

        int i = 0;

        json messageRequest = check req.getJsonPayload();

        string name = messageRequest.name.toString();
        string email = messageRequest.email.toString();
        int age = check <int> messageRequest.age.toString();
        string gender = messageRequest.gender.toString();
        int totalCholesterol = check <int> messageRequest.totalCholesterol.toString();
        int non_hd = check <int> messageRequest.non_hd.toString();
        int ldl = check <int> messageRequest.ldl.toString();
        int hdl =  check <int> messageRequest.hdl.toString();


        int [] data = getCorrectCholesterol(age,gender);

        string template =  calculateCholesterol(name,data,age,gender,totalCholesterol,non_hd,ldl,hdl);


        boolean succ = sendMail(template,email);

        if(succ == true)
        {
            http:Response response;
            response.setPayload("Email Sent Successfully.Please Check You Mail Inbox");
            _=client->respond(response);
        }
        else
        {
            http:Response response;
            response.setTextPayload("Something Went Wrong");
            _=client->respond(response);
        }
    }


}


public function getCorrectCholesterol(int age,string gender) returns int[]{

    json data;

    string sqlQuery;
    int selectedAge;
    string userGender = gender;
    int userAge = age;
    int correctotCholesterol;
    int correctNon_hd;
    int correctldl;
    int correcthdl;
    int[] correctData = [];


    if(age <= 19)
    {
        selectedAge = 19;
    }

    else if(age >= 20)
    {
        selectedAge = 20;
    }


    sqlQuery = "SELECT totalCholesterol,non_hd,ldl,hdl FROM CHOLESTEROL WHERE gender = ? AND age = ?";

    var result = cholesterolDB->select(sqlQuery,(),gender,selectedAge);



    match result {

        table dataTable =>{

            data = check <json>dataTable;
            //correctotCholesterol = check <int> data[0].totalCholesterol;
            //correctNon_hd = check<int> data[0].non_hd;
            //correcthdl = check<int> data[0].hdl;
            //correctldl = check<int> data[0].ldl;
            correctData[0] = check <int> data[0].totalCholesterol;
            correctData[1] = check<int> data[0].non_hd;
            correctData[2] = check<int> data[0].hdl;
            correctData[3] = check<int> data[0].ldl;


        }

        error err =>{
            data  = {"Status":"Data Not Found","Error":err.message};
        }
    }

    return correctData;


}




public function calculateCholesterol(string name,int [] cholData,int age,string gender,int totChol,int non_hd,int ldl,int hdl) returns (string)
{

    string totCholesterolStatus;
    string non_hdStatus;
    string ldlStatus;
    string hdlStatus;

    if(age <= 19)
    {


            if(totChol <= cholData[0])
            {
                totCholesterolStatus = "NORMAL";
            }
            else if(totChol > cholData[0])
            {
                totCholesterolStatus = "HIGH";
            }


            if(ldl <= cholData[2])
            {
                ldlStatus = "NORMAL";
            }
            else if(totChol > cholData[2])
            {
                ldlStatus = "HIGH";
            }

            if(hdl >= cholData[3])
            {
                hdlStatus = "NORMAL";
            }
            else if(hdl < cholData[3])
            {
                hdlStatus = "HIGH";
            }

    }

    if( age > 20)
    {
        if(gender == "male")
        {
            if(totChol <= totChol)
            {
                totCholesterolStatus = "NORMAL";
            }
            else if(totChol > cholData[0])
            {
                totCholesterolStatus = "HIGH";
            }


            if(ldl <= cholData[2])
            {
                ldlStatus = "NORMAL";
            }
            else if(totChol > cholData[2])
            {
                ldlStatus = "HIGH";
            }

            if(hdl >= cholData[3])
            {
                hdlStatus = "NORMAL";
            }
            else if(hdl < cholData[3])
            {
                hdlStatus = "LOW";
            }
        }

        else if(gender == "female"){

            if(totChol <= cholData[0])
            {
                totCholesterolStatus = "NORMAL";
            }
            else if(totChol > cholData[0])
            {
                totCholesterolStatus = "HIGH";
            }


            if(ldl <= cholData[2])
            {
                ldlStatus = "NORMAL";
            }
            else if(totChol > cholData[2])
            {
                ldlStatus = "HIGH";
            }

            if(hdl >= cholData[3])
            {
                hdlStatus = "NORMAL";
            }
            else if(hdl < cholData[3])
            {
                hdlStatus = "HIGH";
            }


        }

    }

   string mailTemplate =  createmailTemplate(name,totCholesterolStatus,ldlStatus,hdlStatus);

    return mailTemplate;


}

public function createmailTemplate(string name,string totChol,string ldlChol,string hdlChol) returns (string)
{

    string emailTemplate = "<h2>Dear " + name + "</h2>";

    emailTemplate = emailTemplate + "<h3> LIPID PROFILE </h3>";

    emailTemplate = emailTemplate + "<p>

            <table>
              <tr>
                <th>Description</th>
                <th>Units</th>
                <th>Remarks</th>
               </tr>
               <tr>
                  <td>CHOLESTEROL TOTAL</td>
                  <td>mg/dl</td>
                  <td>" + totChol + "</td>
               </tr>
               <tr>
                  <td>CHOLESTEROL LDL</td>
                  <td>mg/dl</td>
                  <td>" + ldlChol + "</td>
               </tr>
               <tr>
                  <td>CHOLESTEROL HDL</td>
                  <td>mg/dl</td>
                  <td>" + hdlChol + "</td>
               </tr>
            </table>


    </p>";


    return emailTemplate;

}

function sendMail(string template,string userEmail ) returns (boolean)
{

    gmail:MessageRequest messageRequest;

    messageRequest.sender = sender;
    messageRequest.recipient = userEmail;
    messageRequest.subject = "LIPID Profile";
    messageRequest.messageBody = template;
    messageRequest.contentType = gmail:TEXT_HTML;

    var sendMessageResponse = gmailClient->sendMessage(userId,untaint messageRequest);

    string messageId;
    string threadId;
    match sendMessageResponse {
        (string , string) sendStatus => {
            (messageId, threadId) = sendStatus;
            log:printInfo("Mail Send Successfully");
            return true;

        }
        gmail:GmailError e => {
            log:printInfo(e.message);
            return false;
        }
    }


}