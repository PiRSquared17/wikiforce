@IsTest private class UploadAttachmentControllerTest {
    public static testMethod void test() {
        try{
			GenerateEnvironmentTest.gen();
            Test.startTest(); 
		
			UploadAttachmentController upload = new UploadAttachmentController(); 
			upload.setParentId(GenerateEnvironmentTest.wiki.Id);
			upload.constructMethods();
			upload.setNewAttach(new Attachment(Name = 'Name', Body = Crypto.generateMac('HMacSHA1', Blob.valueOf('String'), Blob.valueOf('String'))));
			upload.getNewAttach();
			upload.getParentId();
			upload.getButtonStyle();
			upload.saveNewAttach();
			upload.cancelAttach();
			
			upload.setParentId(GenerateEnvironmentTest.wiki.Id);
			upload.constructMethods();

            Test.stopTest(); 
        }catch(Exception e){
            throw e;
        }
    }
}