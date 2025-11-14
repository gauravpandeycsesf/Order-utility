/**
 * Provides access to the dependency provider shared by the order application.
 * Consumers retrieve the provider to resolve concrete implementations at runtime.
 */
public with sharing class ApplicationDependencyContext {

    private static ApplicationDependencyProvider provider = new ApplicationDependencyProvider();

    /**
     * Returns the provider responsible for wiring dependencies across the app.
     *
     * @return ApplicationDependencyProvider currently configured provider.
     */
    public static ApplicationDependencyProvider getProvider() {
        return provider;
    }

    /**
     * Replaces the provider for testing or dynamic configuration.
     *
     * @param customProvider provider instance to use, defaults to a new provider when null.
     */
    @TestVisible
    static void setProvider(ApplicationDependencyProvider customProvider) {
        provider = (customProvider == null) ? new ApplicationDependencyProvider() : customProvider;
    }

    /**
     * Restores the default provider instance to remove test overrides.
     */
    @TestVisible
    static void resetProvider() {
        provider = new ApplicationDependencyProvider();
    }
}