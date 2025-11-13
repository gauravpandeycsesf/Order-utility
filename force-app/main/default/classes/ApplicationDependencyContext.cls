public with sharing class ApplicationDependencyContext {

    private static ApplicationDependencyProvider provider = new ApplicationDependencyProvider();

    public static ApplicationDependencyProvider getProvider() {
        return provider;
    }

    @TestVisible
    static void setProvider(ApplicationDependencyProvider customProvider) {
        provider = (customProvider == null) ? new ApplicationDependencyProvider() : customProvider;
    }

    @TestVisible
    static void resetProvider() {
        provider = new ApplicationDependencyProvider();
    }
}