# circleci-dnsimple-orb

## Description

The main goal of this repo is to create a Circle CI orb that connect to DNSimple and create a new record for us, on the `ginetta.dev` domain.

## Commands

-   validate the orb: `circleci orb validate <path to extracted file>`
-   create a new namespace: `circleci namespace create ginetta github ginetta`
-   create an orb and attach it to Ginetta's namespace: `circleci orb create ginetta/dnsimple-test`

## TODOs

-   [] can't [package a shell script](https://discuss.circleci.com/t/packaging-bash-scripts-with-an-orb/33148) inside of an orb, we need to inline it
