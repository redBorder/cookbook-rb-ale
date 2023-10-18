Name:     cookbook-rb-ale
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: ale cookbook to install and configure it in redborder environments

License:  GNU AGPLv3
URL:  https://github.com/redBorder/cookbook-rb-ale
Source0: %{name}-%{version}.tar.gz

%global debug_package %{nil}

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-ale
mkdir -p %{buildroot}/usr/lib64/rb-ale

cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-ale/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-ale
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-ale/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rbale'
  ;;
esac

systemctl daemon-reload
%files
%attr(0755,root,root)
/var/chef/cookbooks/rb-ale
%defattr(0644,root,root)
/var/chef/cookbooks/rb-ale/README.md

%doc

%changelog
* Thu Sep 26 2023 Miguel Negrón <manegron@redborder.com> - 0.0.2
- Add noarch and debug_package in spec file
* Wed Dec 29 2021 Eduardo Reyes <eareyes@redborder.com> - 0.0.1
- first spec version
