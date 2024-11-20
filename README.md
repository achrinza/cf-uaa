<!--
  SPDX-FileCopyrightText: Copyright 2024 Rifa Achrinza
  SDPX-License-Identifier: Apache-2.0
-->
# CloudFoundry UAA for Kubernetes

Tihs repository contains code necessary to:

1. Build a CloudFoundry UAA OCI image with Paketo Buildpacks
2. Deploy CloudFoundry UAA on Kubernetes

Skip to [Deploy to Kubernetes](#deploy-to-kubernetes) if you're ok with using our open-source, pre-made image.

## Build the Image

Ensure that the following are installed:
- Buildpacks `pack` CLI
- Podman or Docker

```sh
$ git clone https://git.sr.ht/~achrinza/cf-uaa
$ ./cf-uaa/create-image.sh
```

The image will be called `cf-uaa`.

## Deploy to Kubernetes

One-liner to deploy a **non-production** instance:

```sh
$ git clone https://git.sr.ht/~achrinza/cf-uaa
$ ytt \
    --file ./cf-uaa/k8s/templates/ \
    --file ./cf-uaa/k8s/addons/local_testing.yml \
    --file ./cf-uaa/k8s/addons/ingress.yml | kubectl apply -f -
```

> [!WARNING]
> Using `local_testing.yml` is insecure. It contains default secrets for the admin account and for generating and validating JWT tokens.

Afterwards, you can retrieve a token and test that it's valid:

```
$ uaa target "http://[K8s Public IP]:8080"
$ uaa get-client-credentials-token \
    admin \
    --client_secret 'FAKE_ADMIN_CLIENT_SECRET'
```

> [!WARNING]
> Production credentials should not be passed directly as command line arguments.
> Use `read -s` and pass the environment variable to the argument instead.

## Deviations from Upstream

Some changes were made from upstream's YTT artifacts:

1. Loading of custom CA Certificates during runtime
  This has been delegated to the CA Cetificate Paekto buildpack.
  This makes the deployment code simpler and shortens startup time by a little bit.
  Read [their docs](https://paketo.io/docs/howto/configuration/#ca-certificates) for info on managing the truststore.

2. Use of Paketo's Jammy Tiny stack instead of VMware Tanzu's Bionic Base stack
  This should be transparent to most users. Ubuntu Bionic is EOL anyways and "tiny" saves a bit of space:
  ```
  $ podman image ls
  cf-uaa latest-base  f25776dec76e  44 years ago  424 MB
  cf-uaa latest-tiny  aad89540f8e4  44 years ago  340 MB
  ```

## License

Apache-2.0
