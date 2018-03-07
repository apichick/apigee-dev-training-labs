var payload = {};
payload.token_type = 'bearer';
payload.issued_at = context.getVariable('issuedAt');
payload.expires_in = context.getVariable('expiresIn');
payload.refresh_token_expires_in = context.getVariable('refreshTokenExpiresIn');
payload.access_token = context.getVariable('accessToken');
var refreshToken = context.getVariable('refreshToken');
if(refreshToken) {
	payload.refresh_token = refreshToken;
}
var scope = context.getVariable('scope');
if(scope) {
	payload.scope = scope;
}
context.setVariable('response.header.Content-Type', 'application/json');
context.setVariable('response.content', JSON.stringify(payload));