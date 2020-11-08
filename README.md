# cf-venona-network-tester
Provides a simple way to test network connectivity issues to a set of provided URLs

## Example
### Usage with docker:
`
docker run --rm --env URLS=https://g.codefresh.io,https://github.com --env DEBUG=1 -it codefresh/cf-venona-network-tester
`

### Environment Variables:
- `URLS` - a list of urls seperated by ",".
- `INSECURE` - disable tls certificate validation when using tls.
- `DEBUG` - can be either '1' or '0', default is '0'.
- `IN_CLUSTER` - if this is set to '1' errors will be written to `/dev/termination-log`. see [here](https://kubernetes.io/docs/tasks/debug-application-cluster/determine-reason-pod-failure/).
- `HTTPS_PROXY`/`https_proxy`
- `HTTP_PROXY`/`http_proxy`
- `NO_PROXY`/`no_proxy`