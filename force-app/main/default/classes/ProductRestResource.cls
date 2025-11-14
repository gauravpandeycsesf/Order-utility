@RestResource(urlMapping='/products/*')
/**
 * REST resource that exposes product search capabilities to external clients.
 */
global with sharing class ProductRestResource {

    /**
     * Provides access to shared dependencies for the resource.
     *
     * @return ApplicationDependencyProvider instance.
     */
    private static ApplicationDependencyProvider dependencies() {
        return ApplicationDependencyContext.getProvider();
    }
    
    /**
     * Returns available products filtered by name and scoped to a pricebook.
     * Query parameters:
     *  - name (optional): substring match for Product2.Name
     *  - pricebookId (required): pricebook that limits the result set
     */
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
            request.parentName = productName;
            
            List<AvailableProductsController.ProductTreeNode> treeNodes = AvailableProductsController.getAvailableProducts(request);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(treeNodes,true));
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse('Error retrieving products: ' + e.getMessage())));
        }
    }
    
    global class ErrorResponse {
        global String error { get; set; }
        
        /**
         * Simple error payload used by the product API.
         *
         * @param errorMessage message returned to the caller.
         */
        public ErrorResponse(String errorMessage) {
            this.error = errorMessage;
        }
    }
}