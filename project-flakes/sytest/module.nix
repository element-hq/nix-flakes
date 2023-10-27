# ci.project-url: https://github.com/matrix-org/sytest
{ pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    # Native dependencies for running Sytest.
    openssl
    # TODO: might need:
    # libsodium
  ];

  # Install the latest version of the perl programming language and required
  # dependencies.
  languages.perl.enable = true;

  # Postgres is needed to run Synapse with postgres support and
  # to run certain unit tests that require postgres.
  services.postgres.enable = true;

  # On the first invocation of `devenv up`, create a database for
  # Synapse to store data in.
  services.postgres.initdbArgs = ["--locale=C" "--encoding=UTF8"];
  services.postgres.initialDatabases = [
    { name = "synapse"; }
  ];
  # Create a postgres user called 'synapse_user' which has ownership
  # over the 'synapse' database.
  services.postgres.initialScript = ''
    CREATE USER synapse_user;
    ALTER DATABASE synapse OWNER TO synapse_user;
  '';

  # Redis is needed in order to run Synapse in worker mode.
  services.redis.enable = true;

  # Define the perl modules we require to run SyTest.
  #
  # This list was compiled by cross-referencing https://metacpan.org/
  # with the modules defined in './cpanfile' and then finding the
  # corresponding Nix packages on https://search.nixos.org/packages.
  #
  # This was done until `./install-deps.pl --dryrun` produced no output.
  env.PERL5LIB = "${with pkgs.perl536Packages; makePerlPath [
    DBI
    ClassMethodModifiers
    CryptEd25519
    DataDump
    DBDPg
    DigestHMAC
    DigestSHA1
    EmailAddressXS
    EmailMIME
    EmailSimple  # required by Email::Mime
    EmailMessageID  # required by Email::Mime
    EmailMIMEContentType  # required by Email::Mime
    TextUnidecode  # required by Email::Mime
    ModuleRuntime  # required by Email::Mime
    EmailMIMEEncodings  # required by Email::Mime
    FilePath
    FileSlurper
    Future
    GetoptLong
    HTTPMessage
    IOAsync
    IOAsyncSSL
    IOSocketSSL
    NetSSLeay
    JSON
    ListUtilsBy
    ScalarListUtils
    ModulePluggable
    NetAsyncHTTP
    MetricsAny  # required by Net::Async::HTTP
    NetAsyncHTTPServer
    StructDumb
    URI
    YAMLLibYAML
  ]}";
}