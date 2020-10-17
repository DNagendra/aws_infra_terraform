# infini-devops

Terraform module to create the infini Infrastructure from grond-up using a single command. For now, this REPO contains two folders
1. infini - Dev environment for a tenant called "infini", which is up & running
2. modules - all modules needed to spin up a tenant
3. infini-uat - QA environment for a tenant called "infini",which is up and running.

## What to do to onboard a new tenant?
Steps are 
1. Create a new folder with the tenant name 
2. Create a main.tf with all necessacry inputs like tenant name, VPC address etc., 
3. Execute ``` terrafrom apply ``` after ``` terraform init``` and ``` terraform plan``` from the newly created folder
4. The Infrastructure for the new tenant should be created from URL should be provided to client to access
5. Get the rds DB instance details and connect from ec2 instance with mysql client installed.
6. create ec2 instance to access the db
7. Update your system by running: sudo yum update
8. Install mysql client on Amazon Linux AMI by typing:  sudo yum install mysql57
9. Install existing client, run: sudo yum install mysql57
10. connect to database. sample command for QA DB below and enter the password
11. mysql -h infini-qa-instance.clo2fyyn2ezx.us-east-2.rds.amazonaws.com -P 3306 -u infiniuat -p

show databases;
use <databasename>;
show tables;

12. Run your insert queires to add the users to the database and provide necessary roles to user to access the application.

refer `infini` tenant folder for next steps for each environment specific instructions.

