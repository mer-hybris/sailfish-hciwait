Name: sailfish-hciwait
Version: 1.0.0
Release: 1
Summary: Sailfish hciwait service
Group: Communications/ConnMan
License: GPLv2
URL: https://github.com/mer-hybris/sailfish-hciwait
Source: %{name}-%{version}.tar.bz2
Requires: bluez
Requires: bluez-libs
BuildRequires: pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(dbus-1)
BuildRequires: bluez-libs
BuildRequires: bluez-libs-devel
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description
This package contains the Sailfish hciwait service.

%prep
%setup -q -n %{name}-%{version}

%build
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%make_install

mkdir -p %{buildroot}/%{_lib}/systemd/system/network.target.wants
ln -s ../sailfish-hciwait.service %{buildroot}/%{_lib}/systemd/system/network.target.wants/sailfish-hciwait.service

%preun
if [ "$1" -eq 0 ]; then
systemctl stop sailfish-hciwait.service || :
fi

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_sbindir}/sailfish-hciwait
/%{_lib}/systemd/system/sailfish-hciwait.service
/%{_lib}/systemd/system/network.target.wants/sailfish-hciwait.service
