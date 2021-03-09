
class AppViewController < UIViewController
  attr_reader :current_nonce

  def viewDidLoad
    margin = 20

    appleButton = ASAuthorizationAppleIDButton.buttonWithType(ASAuthorizationAppleIDButtonTypeSignIn, style: ASAuthorizationAppleIDButtonStyleBlack)
    appleButton.cornerRadius = 12
    appleButton.frame = [[margin, 100], [view.frame.size.width - margin * 2, 40]]
    self.view.addSubview appleButton
    appleButton.addTarget(self, action: 'handle_signin_button_click',
      forControlEvents: UIControlEventTouchUpInside)

    # puts ASAuthorizationScopeFullName
    # puts ASAuthorizationScopeEmail

    # setupFirebase
  end

  def viewDidAppear(animated)
    self.perform_existing_account_setup_flows
  end

  def perform_existing_account_setup_flows
    # Prepare requests for both Apple ID and password providers
    requests = [
      ASAuthorizationAppleIDProvider.new.createRequest,
      ASAuthorizationPasswordProvider.new.createRequest
    ]

    #  Create an authorization controller with the given requests
    authorizationController = ASAuthorizationController.alloc.initWithAuthorizationRequests requests
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests
  end

  def start_sign_in_with_apple_flow
    appleSignInHelper = FIRAppleSignInHelper.new

    @current_nonce = appleSignInHelper.randomNonce 32

    appleIDProvider = ASAuthorizationAppleIDProvider.alloc.init
    request = appleIDProvider.createRequest
    request.requestedScopes = [ASAuthorizationScopeFullName, ASAuthorizationScopeEmail]
    request.nonce = appleSignInHelper.stringBySha256HashingString self.current_nonce

    requests = [request]

    authorizationController = ASAuthorizationController.alloc.initWithAuthorizationRequests requests
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests
  end

  def setupFirebase
    # Initialize the root of our Firebase namespace.
    Firebase.configure
  end

  def handle_signin_button_click
    self.start_sign_in_with_apple_flow
  end

  # ASAuthorizationControllerDelegate
  def authorizationController(controller, didCompleteWithAuthorization: authorization)
    NSLog("authorization controller %@ %@", controller, authorization)
    if authorization.credential.is_a? ASAuthorizationAppleIDCredential
      appleIDCredential = authorization.credential
      rawNonce = self.current_nonce
      raise "Invalid state: A login callback was received, but no login request was sent." if rawNonce.nil?

      if appleIDCredential.identityToken.nil?
        NSLog("Unable to fetch identity token.")
        return
      end

      idToken = NSString.alloc.initWithData(appleIDCredential.identityToken, encoding:NSUTF8StringEncoding)
      if idToken.nil?
        NSLog("Unable to serialize id token from data: %@", appleIDCredential.identityToken)
      end

      credential = FIROAuthProvider.credentialWithProviderID("apple.com", IDToken:idToken, rawNonce:rawNonce)

      Firebase.auth.signInWithCredential(credential,
                              completion: -> (authResult, error) do
        if error
          NSLog("Sign in with Apple completed with error: %@", error)
          # Error. If error.code == FIRAuthErrorCodeMissingOrInvalidNonce,
          # make sure you're sending the SHA256-hashed nonce as a hex string
          # with your request to Apple.
          return
        else
          # Sign-in succeeded
        end
      end)
    end
  end

  def authorizationController(controller, didCompleteWithError: error)
    NSLog("Sign in with Apple errored: %@", error)
  end

  # ASAuthorizationControllerPresentationContextProviding
  def presentationAnchor(controller)
    self.view.window
  end
end
