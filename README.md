# Repository for docker image for running dv-ros driver
Problem this tries to solve: running dv-ros on weak hardware like the raspberry pi 5 can cause the ringbuffer of incoming events to overflow.  \
Solution: during the docker-build path dv-processing to have a larger buffer  \
    additionally add logging in case of overflow.  \

# How to use
## docker build
`cat docker-build | bash`

## docker run
In the `docker-run` file are 2 docker run commands, one for graphical session (top), one for headless sessions.  \

## For USB problems
Take a look at `usb-rule`.  \

## Capturing events from inside the container
Use `capture_sess.sh` to automatically start a tmux-session for event capture.  \

## Notes
dv-processing version is pinned in the Dockerfile, if you remove the version pinning it will pull the most up to date version, but this can break the patch.

## References

- [dv-processing source code](https://gitlab.com/inivation/dv/dv-processing)
- [dv-processing documentation](https://dv-processing.inivation.com/)
- [dv-processing API reference](https://dv-processing.inivation.com/master/api.html)

- [dv-ros source code](https://gitlab.com/inivation/dv/dv-ros)
- [iniVation PPA with dv-processing packages](https://launchpad.net/~inivation-ppa/+archive/ubuntu/inivation)

