import ballerina/io;
import ballerina/http;

endpoint http:Client clientEndpoint {
    url: "http://localhost:9090"
};


function main(string... args) {

    int c = 0;
    http:Request req = new;


    io:println("Select Operation");
    io:println("1. User");
    io:println("2. Developer");
    io:println("3. Exit");

    string choice = io:readln("Enter Your Choice : ");
     c = check <int> choice;

    if(c == 1)
    {
        callUser();

    }

    if(c == 2)
    {
        callDeveloper();
    }



}

function  callUser ()   {

    http:Request req = new;

    string name = io:readln("Enter Your Name : ");
    string email = io:readln("Enter Your Email Address : ");
    int age  = check <int>io:readln("Enter Your Age : ");
    string gender = io:readln("Enter Your Gender : ");
    int totChol = check <int>io:readln("Enter Your Total Cholesterol Level : ");
    int non_hd  = check <int>io:readln("Enter Your Non Hd Cholesterol Level : ");
    int ldl  = check <int>io:readln("Enter Your LDL Cholertorl Level : ");
    int hdl = check <int>io:readln("Enter Your HDL Cholesterol Level : ");



    json jsonMessage = {
        name:name,
        age:age,
        email:email,
        gender:gender,
        totalCholesterol:totChol,
        non_hd:non_hd,
        ldl:ldl,
        hdl:hdl

    };

    req.setJsonPayload(jsonMessage);


    var response = clientEndpoint->post("/user/cholesterol",req);

    match response {

        http:Response resp=>{

            var msg = resp.getTextPayload();

            match msg {

                string payload=>{
                    io:println(payload);
                }

                error err =>{
                    io:println(err.message);
                }

            }


            }

        error err =>{
            log:printError(err.message);
        }
    }


}

function callDeveloper ()   {
    var developerResponse =   clientEndpoint->get("/developer/cholesterol");
}