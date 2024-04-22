public with sharing class GoogleDriveFileUpload {
    public GoogleDriveFileUpload() {

    }
    // Map to hold FileType to MIME type mapping
    private static Map<String, String> fileTypeToMIMEMap = new Map<String, String>{
        'PDF' => 'application/pdf',
        'EXCEL' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // for .xlsx files
        'WORD' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // for .docx files
        'PNG' => 'image/png',
        'JPG' => 'image/jpeg',
        'JPEG' => 'image/jpeg',
        'PPT' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation', // for .pptx files
        'TEXT' => 'text/plain',
        'CSV' => 'text/csv'
        // Add other file types as needed
    };
    public static String uploadFiletoGDrive(String cvId,String folderId)
    {
        String fileId;
        folderId = '1b-acH9AWFgtpNkXqCGMmEq8nZ9C0Xg6g';
        // get contentversion
        ContentDocument document = [SELECT Title FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvId)];
        ContentVersion cv = [SELECT ContentDocumentId,VersionData,fileType FROM ContentVersion WHERE Id = :cvId];
        String fileName = document.Title;

        System.debug('file Name '+ fileName);

    // Prepare the metadata for the file, including the name and parent folder ID

        String metadata = JSON.serialize(new Map<String, Object>{
            'name' => fileName,
            'parents' => new List<String>{folderId}
        });

        String boundary = '-------314159265358979323846';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String contentType = getMIMEType(cv.fileType); // Adjust this based on your file type
        // Combine the metadata and file content into a single request body
        String requestBody = '--foo_bar_baz\r\nContent-Type: application/json;charset=UTF-8\r\n\r\n' + metadata + '\r\n\r\n--foo_bar_baz\r\n' +
    'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n\r\n' + EncodingUtil.base64Encode(cv.VersionData) +  '\r\n--foo_bar_baz--';

    // Prepare the HttpRequest

    HttpRequest req = new HttpRequest();
    
    req.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
    req.setMethod('POST');
    req.setEndpoint('callout:GDriveFileUpload');
    //req.setHeader('Content-Length', String.valueOf(requestBody.length()));
    req.setBody(requestBody);
    // Send the request
// Send the request
        System.debug('requestbody-->'+requestBody);
    Http http = new Http();
    HttpResponse response = http.send(req);
    System.debug(response.getBody());
    return fileId;

    }

    public static String getGDriveFileList()
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

    

    // Method to get MIME type from FileType
    public static String getMIMEType(String fileType) {
        // Check if the map contains the FileType
        if (fileTypeToMIMEMap.containsKey(fileType)) {
            return fileTypeToMIMEMap.get(fileType);
        } else {
            // Return a default MIME type or null if FileType is not recognized
            return 'application/octet-stream'; // This is a generic MIME type for binary data
        }
    }
}