{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  nodeDatachannelPrebuild = fetchurl {
    url = "https://github.com/murat-dogan/node-datachannel/releases/download/v0.32.3/node-datachannel-v0.32.3-napi-v8-linux-x64.tar.gz";
    hash = "sha256-QJKvyc1ZSjMm6xvYI9pFKyJ7dC6oIiaJss6m9zRM9no=";
  };
in
buildNpmPackage rec {
  pname = "webtorrent-cli";
  version = "6.0.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-y2hQSUA4FANmce83JlA5H70d9/6BqlYmiycp2IG6FfU=";
  };

  nodejs = nodejs_22;
  npmDepsHash = "sha256-vU38NuP3+l6BkJ5kwr8Ri0ANhTEo3xnDVj3wbVXshx4=";

  postPatch = ''
    sed -i '/"devDependencies": {/,/  },/d' package.json
    cp ${./webtorrent-cli.package-lock.json} package-lock.json
  '';

  npmInstallFlags = [ "--omit=dev" ];
  # buildNpmPackage installs with --ignore-scripts and then runs `npm rebuild`.
  # Keep that rebuild from triggering ip-set's package-manager policy script;
  # rebuild the actual native addons explicitly below.
  npmRebuildFlags = [ "--ignore-scripts" ];

  preBuild = ''
    npm rebuild bufferutil utf-8-validate utp-native
    tar -xzf ${nodeDatachannelPrebuild} -C node_modules/node-datachannel
  '';

  dontNpmBuild = true;

  meta = {
    description = "WebTorrent streaming torrent client for the command line";
    homepage = "https://github.com/webtorrent/webtorrent-cli";
    license = lib.licenses.mit;
    mainProgram = "webtorrent";
    platforms = [ "x86_64-linux" ];
  };
}
