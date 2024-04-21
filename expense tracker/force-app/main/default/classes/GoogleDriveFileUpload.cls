public with sharing class GoogleDriveFileUpload {
    public GoogleDriveFileUpload() {

    }

    public static String uploadFiletoGDrive()
    {
        String fileId;
        HttpRequest req = New HttpRequest();
        req.setEndpoint('callout:GoogleDrive');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('--->'+res.getBody());
        return fileId;

    }
}