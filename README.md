# circleci-dnsimple-orb

## Description

The main goal of this repo is to create a Circle CI orb that connect to DNSimple and create a new record for us, on the `ginetta.dev` domain.

## Commands

-   validate the orb: `circleci orb validate dns-orb.yml`
-   create a new namespace: `circleci namespace create ginetta github ginetta`
-   create an orb and attach it to Ginetta's namespace: `circleci orb create ginetta/dnsimple`
-   publish the orb: `circleci orb publish dns-orb.yml ginetta/dnsimple@0.0.1`
-   remove an existing orb: `circleci orb unlist ginetta/dnsimple`
