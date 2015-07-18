{ packages }:

let

  haskellPackages = packages.override {
    overrides = self : super : {
      lambdabot-core = self.callPackage ./lambdabot-core { };
      lambdabot-haskell-plugins = self.callPackage ./lambdabot-haskell-plugins { };
      lambdabot-reference-plugins = self.callPackage ./lambdabot-reference-plugins { };
      slack-api = self.callPackage ../slack-api { };
    };
  };

in

  haskellPackages.callPackage
