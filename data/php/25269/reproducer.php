<?php
set_error_handler(function($errno, $errstr) {
    throw new ErrorException($errstr);
});
class AzureAuthHelper {
    public static function getAzureEnvironment($env) {
        $validEnvs = [
            null => 1, "" => 1, " " => 1, "azure" => 1, "AZURE_CLOUD" => 1,
        ];
        return $validEnvs[strtolower(trim($env))] ?? 1;
    }
}
AzureAuthHelper::getAzureEnvironment("unknown");
