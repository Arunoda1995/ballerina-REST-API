import ballerina/io;

endpoint http:Client clientEndpoint {
    url:"http://localhost:9090"
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

    var userResponse = clientEndpoint->get("/user/cholesterol");

}

function callDeveloper ()   {
    var developerResponse =   clientEndpoint->get("/developer/cholesterol");
}