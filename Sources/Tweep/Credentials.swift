import Foundation

public enum OAuth {}

public actor Credentials {
    public private(set) var consumerKey: String?
    public private(set) var consumerSecret: String?
    public private(set) var bearerToken: String?
    public private(set) var accessTokenKey: String?
    public private(set) var accessTokenSecret: String?
    
    public private(set) var oauth: OAuth?
    
    init(
        consumerKey: String?,
        consumerSecret: String?,
        bearerToken: String?
    ) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        
        // Reasonably, some clients provide the authorization header as the bearer
        // token. In this case we automatically strip the bearer prefix to normalize
        // the credentials.
        if let token = bearerToken, token.starts(with: "Bearer ") {
            self.bearerToken = String(token.dropFirst(7))
        } else {
            self.bearerToken = bearerToken
        }
    }
    
    init(
        consumerKey: String,
        consumerSecret: String,
        accessTokenKey: String,
        accessTokenSecret: String
    ) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        
        self.accessTokenKey = accessTokenKey
        self.accessTokenSecret = accessTokenSecret
        
//      this._oauth = new OAuth({
//        consumer: {
//          key: args.consumer_key,
//          secret: args.consumer_secret,
//        },
//        signature_method: 'HMAC-SHA1',
//        hash_function(base_string, key) {
//          return crypto
//            .createHmac('sha1', key)
//            .update(base_string)
//            .digest('base64');
//        },
//      });
    }
}

extension Credentials {
    var isAppAuth: Bool {
        self.accessTokenKey == nil && self.accessTokenSecret == nil
    }
    
    var isUserAuth: Bool {
        !isAppAuth
    }
    
    func createBearerToken() async throws {
        guard isAppAuth else {
            throw TwitterError.userAuthBearer
        }
        
        guard bearerToken == nil else { return }
        
        let token = try await Bearer.generateToken(
            consumerKey: consumerKey!,
            consumerSecret: consumerSecret!
        )
        
        bearerToken = token
    }
    
    struct AuthorizationRequest<Body> {
        let method: String
        let body: Body?
    }
    
    func authorizationHeader<Body>(url: URL, request: AuthorizationRequest<Body>) async throws -> String {
        if isAppAuth {
            try await createBearerToken()
            return "Bearer \(bearerToken!)"
        }
        
        if oauth == nil {
            throw TwitterError.undefinedOAuth
        } else if accessTokenKey == nil || accessTokenSecret == nil {
            throw TwitterError.undefinedAccessToken
        }
        
        return ""
//          return this._oauth.toHeader(
//          this._oauth.authorize(
//            {
//              url: url.toString(),
//              method: request.method,
//              data: request.body,
//            },
//            {
//              key: this.access_token_key,
//              secret: this.access_token_secret,
//            }
//          )
//        ).Authorization
    }
}

extension Credentials.AuthorizationRequest where Body == Never {
    init(method: String) {
        self.method = method
        self.body = nil
    }
}

fileprivate extension TwitterError {
    static let userAuthBearer: Self = "Cannot create a bearer token when using user authentication"
    static let undefinedOAuth: Self = "OAuth should be defined for user authentication"
    static let undefinedAccessToken: Self = "Access token should be defined for user authentication"
}
