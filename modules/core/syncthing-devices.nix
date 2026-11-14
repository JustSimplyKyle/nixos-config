# Syncthing device IDs, derived from hosts/HOST/syncthing-cert.pem
# The matching private keys live in secrets/syncthing-HOST.yaml
# New host: syncthing generate --home=/tmp/st, copy cert.pem to hosts/HOST/syncthing-cert.pem,
# encrypt key.pem into secrets/syncthing-HOST.yaml (as syncthing-key) and add the printed ID here
{
  nixos-desktop = "5FCMHMN-2QKFI2L-DJMRSCY-VXMGKJR-HWGEDOE-664IQ4C-Q7UIAEL-LGY6PAR";
  nixos-portable = "MSACGKK-NSDQLBO-S2OJ66L-5JX7GAV-5J2MXJG-RTXVDS6-FXMQ7CY-XET43AX";
}
