# Five or More - Compilation and Installation Guide

## Overview

Five or More is a GNOME puzzle game written in Vala. This guide provides instructions for compiling and installing the application from source code.

## Prerequisites

### System Requirements

- Linux distribution with GNOME development libraries
- Meson build system (>= 0.57.0)
- Vala compiler
- C compiler (GCC or Clang)

### Required Dependencies

Install the following development packages using your distribution's package manager:

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install meson valac gcc pkg-config
sudo apt install libglib2.0-dev libgtk-3-dev libgee-0.8-dev
sudo apt install libgnome-games-support-1-dev librsvg2-dev
sudo apt install gettext appstream-util desktop-file-utils
```

#### Fedora/RHEL/CentOS
```bash
sudo dnf install meson vala gcc pkgconfig
sudo dnf install glib2-devel gtk3-devel libgee-devel
sudo dnf install libgnome-games-support-devel librsvg2-devel
sudo dnf install gettext appstream-util desktop-file-utils
```

#### Arch Linux
```bash
sudo pacman -S meson vala gcc pkgconf
sudo pacman -S glib2 gtk3 libgee
sudo pacman -S libgnome-games-support librsvg
sudo pacman -S gettext appstream-glib desktop-file-utils
```

### Dependency Details

The application requires the following libraries with minimum versions:

- **GLib**: >= 2.32 (Core library for data structures and utilities)
- **GTK+**: >= 3.24.0 (GUI toolkit)
- **libgee**: 0.8 (Collection library for Vala)
- **libgnome-games-support**: >= 1.7.1 (GNOME games common functionality)
- **librsvg**: >= 2.32.0 (SVG rendering library)
- **GModule**: For dynamic module loading

## Compilation Process

### 1. Clone or Extract Source Code

If using Git:
```bash
git clone https://gitlab.gnome.org/GNOME/five-or-more.git
cd five-or-more
```

If using a source tarball:
```bash
tar -xf five-or-more-*.tar.xz
cd five-or-more-*
```

### 2. Configure Build

Create a build directory and configure the project:

```bash
meson setup builddir
```

#### Build Configuration Options

You can customize the build with various options:

```bash
# Install to custom prefix (default: /usr/local)
meson setup builddir --prefix=/usr

# Enable debug build
meson setup builddir --buildtype=debug

# View all available options
meson configure builddir
```

### 3. Compile the Application

```bash
meson compile -C builddir
```

This will:
- Compile Vala source files to C
- Compile C code to object files
- Link the final executable
- Process resource files and translations
- Generate desktop files and metadata

### 4. Run Tests (Optional)

```bash
meson test -C builddir
```

## Installation

### System-wide Installation

Install the application system-wide (requires root privileges):

```bash
sudo meson install -C builddir
```

This installs:
- Executable: `/usr/local/bin/five-or-more`
- Data files: `/usr/local/share/five-or-more/`
- Desktop file: `/usr/local/share/applications/`
- Icons: `/usr/local/share/icons/hicolor/`
- Translations: `/usr/local/share/locale/`
- GSchema: `/usr/local/share/glib-2.0/schemas/`

### Post-Installation Steps

After installation, update system databases:

```bash
# Update desktop database
sudo update-desktop-database

# Update icon cache
sudo gtk-update-icon-cache /usr/local/share/icons/hicolor/

# Compile GSettings schemas
sudo glib-compile-schemas /usr/local/share/glib-2.0/schemas/
```

### User Installation

For user-only installation without root privileges:

```bash
meson setup builddir --prefix=$HOME/.local
meson compile -C builddir
meson install -C builddir

# Update user databases
update-desktop-database ~/.local/share/applications/
gtk-update-icon-cache ~/.local/share/icons/hicolor/
glib-compile-schemas ~/.local/share/glib-2.0/schemas/
```

## Running the Application

### From Installation

If installed system-wide:
```bash
five-or-more
```

Or launch from the applications menu in your desktop environment.

### From Build Directory (Development)

Run without installing:
```bash
./builddir/src/five-or-more
```

## Troubleshooting

### Common Build Issues

#### Missing Dependencies
```
ERROR: Dependency "libgnome-games-support-1" not found
```
**Solution**: Install the missing development package for your distribution.

#### Vala Compiler Issues
```
ERROR: Program 'valac' not found
```
**Solution**: Install the Vala compiler package (`valac` or `vala`).

#### Meson Version
```
ERROR: Meson version is 0.50.0 but project requires >= 0.57.0
```
**Solution**: Update Meson or install from pip: `pip3 install --user meson`

### Runtime Issues

#### Missing Schemas
```
GLib-GIO-ERROR: Settings schema 'org.gnome.five-or-more' is not installed
```
**Solution**: Run `glib-compile-schemas` on the schemas directory.

#### Missing Icons
If icons don't appear, update the icon cache:
```bash
gtk-update-icon-cache /usr/local/share/icons/hicolor/
```

### Development Setup

For development work:

```bash
# Configure with debug symbols
meson setup builddir --buildtype=debug

# Enable additional warnings
meson configure builddir -Dwarning_level=2

# Install development dependencies
sudo apt install gdb valgrind  # Ubuntu/Debian
```

## Uninstallation

### From Meson Build

If you kept the build directory:
```bash
sudo ninja uninstall -C builddir
```

### Manual Removal

Remove installed files manually:
```bash
sudo rm /usr/local/bin/five-or-more
sudo rm -rf /usr/local/share/five-or-more/
sudo rm /usr/local/share/applications/org.gnome.five-or-more.desktop
sudo rm /usr/local/share/glib-2.0/schemas/org.gnome.five-or-more.gschema.xml
# Remove icons from /usr/local/share/icons/hicolor/*/apps/org.gnome.five-or-more.*
```

## Additional Resources

- [GNOME Developer Documentation](https://developer.gnome.org/)
- [Meson Build System](https://mesonbuild.com/)
- [Vala Programming Language](https://vala.dev/)
- [Five or More GitLab Repository](https://gitlab.gnome.org/GNOME/five-or-more)