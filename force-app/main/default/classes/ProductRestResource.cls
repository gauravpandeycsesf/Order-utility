@RestResource(urlMapping='/products/*')
global with sharing class ProductRestResource {

    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    @HttpGet
    global static void getProductsByName() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String productName = req.params.get('name');
            String pricebookId = req.params.get('pricebookId');
            
            if (String.isBlank(pricebookId)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Pricebook ID parameter is required')));
                return;
            }
            
            AvailableProductsController.AvailableProductsRequest request = new AvailableProductsController.AvailableProductsRequest();
            request.pricebookId = Id.valueOf(pricebookId);
            request.productName = productName;
            
            List<AvailableProductsController.ProductTreeNode> treeNodes = AvailableProductsController.getAvailableProducts(request);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(treeNodes));
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Error retrieving products: ' + e.getMessage())));
        }
    }
    
    global class ErrorResponse {
        global String error { get; set; }
        
        public ErrorResponse(String errorMessage) {
            this.error = errorMessage;
        }
    }
}