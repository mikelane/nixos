{
  networking.extraHosts = ''
    127.0.0.1   api.local.rewst.io
    127.0.0.1   app.local.rewst.io
    127.0.0.1   engine.local.rewst.io
    192.168.49.2   api.minikube.rewst.io
    192.168.49.2   app.minikube.rewst.io
    192.168.49.2   engine.minikube.rewst.io
    192.168.49.2   grafana.minikube.rewst.io
    192.168.49.2   kafka-ui.minikube.rewst.io
    192.168.49.2   kiali.minikube.rewst.io
    192.168.49.2   grafana.local.rewst.io
    192.168.49.2   kafka-ui.local.rewst.io
    192.168.49.2   kiali.local.rewst.io
    192.168.2.40   qa.c9xkwgfwwjv3.us-east-2.rds.amazonaws.com
  '';
}
