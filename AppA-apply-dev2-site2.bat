@ECHO OFF

:: Terraform build wrapper script
:: John Bencic


SET HOURPAD=%TIME: =0%
SET DATEf=%date:~10,4%%date:~7,2%%date:~4,2%.%HOURPAD:~0,2%%time:~3,2%

SET TF_VAR_environment=dev2
SET TF_VAR_site=2
SET TF_VAR_app=appa
SET BASEDIR=D:\Provisioning\Terraform\terraform-environments


SET NAME=%TF_VAR_app%-%TF_VAR_environment%
SET BUILDNAME=%NAME%_%DATEf%

SET TF_LOG=TRACE
SET TF_LOG_PATH=%BASEDIR%\logs\%BUILDNAME%.log

%BASEDIR:~0,2%
cd %BASEDIR%
echo %CD%


echo "... Updating modules"
%BASEDIR%\bin\terraform get -update=true -no-color %BASEDIR%\templates\%TF_VAR_app%

echo "... Building %BUILDNAME%"
%BASEDIR%\bin\terraform apply ^
-no-color ^
-state=%BASEDIR%\%TF_VAR_app%_%TF_VAR_environment%_Site%TF_VAR_site%.tfstate ^
%BASEDIR%\templates\%TF_VAR_app%

pause

