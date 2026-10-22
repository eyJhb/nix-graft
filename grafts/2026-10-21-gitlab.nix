# GitLab 19.4.3 patch release, taken whole from a nixpkgs revision that has it:
#   CVE-2026-105777  internal server credentials exposed via response headers (unauthenticated)
#   CVE-2026-13319   group milestones API leaks private project milestones
#   CVE-2026-112378  paid AI features without a subscription (EE)
#   CVE-2026-105711  confidential issue titles leaked via shared fragment cache
#   CVE-2026-14288   merge request approval policy bypass on protected branches (EE)
#   CVE-2026-112326  read-only users can delete vulnerability records (EE)
#   CVE-2026-103515  group owners can bypass admin lock on Duo / Amazon Q (EE)
{
  pkgs,
  lib,
  nixpkgsAt,
  ...
}:
let
  version = "19.4.3";
  minVersion = "19.0.0";

  # nixpkgs commit "gitlab: 19.4.2 -> 19.4.3"
  updated = nixpkgsAt "5cd4e1c09c37aba4c5611178ac5f6f7f9dfb6750" "sha256-XxVJSBA1Ac5wj4PK/SVUbortIfQ7wlSriTgkLqTxtl0=";
in
{
  reason = "GitLab ${version} security release";
  advisory = "https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/";
  cves = [
    "CVE-2026-105777"
    "CVE-2026-13319"
    "CVE-2026-112378"
    "CVE-2026-105711"
    "CVE-2026-14288"
    "CVE-2026-112326"
    "CVE-2026-103515"
  ];
  applies =
    let
      gitlabVersion = lib.getVersion pkgs.gitlab;
    in
    lib.versionAtLeast gitlabVersion minVersion && lib.versionOlder gitlabVersion version;
  old = pkgs.gitlab;
  new = updated.gitlab;
  also = [
    {
      old = pkgs.gitaly;
      new = updated.gitaly;
    }
    {
      old = pkgs.gitlab-pages;
      new = updated.gitlab-pages;
    }
    {
      old = pkgs.gitlab-workhorse;
      new = updated.gitlab-workhorse;
    }
  ];
}
