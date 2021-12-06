/**
 * Created by thom on 7/9/18.
 */

public with sharing class LegalServerXmlCalloutMock implements HttpCalloutMock {


    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/xml');
        response.setBody(
                '<html>' +
                        '<body>' +
                        '<form action="intake_xml.php" method="post"' +
                        'enctype="multipart/form-data" accept-charset="utf-8">' +
                        '<fieldset style="width: 50em;">' +
                        '<p>Sample data is <a href="/static/external_xml_intake/sample_intake.xml">here</a></p>' +
                        '<p>XML Schema is <a href="/static/external_xml_intake/external_intake.xsd">here</a></p>' +
                        '<p>' +
                        'Lookup enumerated types schema is <a href="/static/external_xml_intake/lookup.xsd">here</a>' +
                        '</p>' +
                        '<p>Sample ASP submission code is ' +
                        '<a href="/static/external_xml_intake/sample_intake_submit.aspx">here</a></p>' +
                        '<p>Pick one of the following methods for upload</p>' +
                        '<label for="file">File Upload:</label>' +
                        '<input type="file" name="file" id="file" />' +
                        '<br />OR<br />' +
                        '<label for="xmltext">Paste XML Here:</label>' +
                        '<p><textarea name="xmltext" style="height: 10em; width: 30em;">' +
                        '</textarea>' +
                        '</p>' +
                        '</fieldset>' +
                        '<br />' +
                        '<input type="submit" name="submit" value="Submit" />' +
                        '</form>' +
                        '</body>' +
                        '</html>'
        );
        response.setStatusCode(200);
        return response;
    }
}