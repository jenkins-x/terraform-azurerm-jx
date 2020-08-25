package test

import (
	"context"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/preview/containerregistry/runtime/2019-08-15-preview/containerregistry"
	"github.com/Azure/go-autorest/autorest/adal"
	"github.com/Azure/go-autorest/autorest/azure/auth"
)

const activeDirectoryEndpoint = "https://login.microsoftonline.com/"
const ArmResource = "https://management.core.windows.net/"
const AzureStorageResourceID = "https://storage.azure.com/"

func getAzureADToken(resourceID string, clientId string, clientSecret string) (adal.Token, error) {

	authEnv, err := auth.GetSettingsFromEnvironment()
	if err != nil {
		return adal.Token{}, fmt.Errorf("failed to get Azure auth environment variables, %w", err)
	}

	clientCredentialsConfig, err := authEnv.GetClientCredentials()
	if err != nil {
		return adal.Token{}, fmt.Errorf("failed to get client credentials grant variables from environment, %w", err)
	}

	if clientId != "" {
		clientCredentialsConfig.ClientID = clientId
	}

	if clientSecret != "" {
		clientCredentialsConfig.ClientSecret = clientSecret
	}

	oauthConfig, err := adal.NewOAuthConfig(activeDirectoryEndpoint, clientCredentialsConfig.TenantID)

	if err != nil {
		return adal.Token{}, fmt.Errorf("failed to create OAuthConfig, %w", err)
	}

	spt, err := adal.NewServicePrincipalToken(
		*oauthConfig,
		clientCredentialsConfig.ClientID,
		clientCredentialsConfig.ClientSecret,
		resourceID,
		func(t adal.Token) error { return nil })

	if err != nil {
		return adal.Token{}, fmt.Errorf("failed to create identity token, %w", err)
	}

	err = spt.Refresh()
	if err != nil {
		return adal.Token{}, fmt.Errorf("failed to refresh ARM token, %w", err)
	}
	return spt.Token(), nil
}

func getRegistryAccessToken(armAccessToken string, loginURI string, registryName string, tenantId string, scope string) (string, error) {

	ctx := context.Background()
	authorizer, err := auth.NewAuthorizerFromEnvironment()

	if err != nil {
		return "", fmt.Errorf("failed to get Azure authorizer from environment variables - %w", err)
	}

	refreshTokenClient := containerregistry.NewRefreshTokensClient(loginURI)
	refreshTokenClient.Authorizer = authorizer

	rt, err := refreshTokenClient.GetFromExchange(ctx, "access_token", registryName, tenantId, "", armAccessToken)

	if err != nil {
		return "", fmt.Errorf("failed to get refresh token for container registry - %w", err)
	}

	accessTokenClient := containerregistry.NewAccessTokensClient(loginURI)
	accessTokenClient.Authorizer = authorizer

	registryAccessToken, err := accessTokenClient.Get(ctx, registryName, scope, *rt.RefreshToken)

	if err != nil {
		return "", fmt.Errorf("failed to get access token for container registry - %w", err)
	}

	return *registryAccessToken.AccessToken, nil
}
