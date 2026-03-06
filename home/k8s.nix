{ pkgs, ... }: {
  home.packages = with pkgs; [
    dyff
    kubectl
    kustomize
    kubernetes-helm
  ];
}
