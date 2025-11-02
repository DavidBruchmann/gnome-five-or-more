# Desktop file
desktop = 'org.gnome.five-or-more.desktop'
desktop_file = i18n.merge_file (
  input: desktop + '.in',
  output: desktop,
  type: 'desktop',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths (data_dir, 'applications')
)
desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
  test(
    'validate-desktop',
    desktop_file_validate,
    args: [
      desktop_file.full_path()
    ]
  )
endif

# Themes
foreach file: ['balls.svg', 'shapes.svg', 'tango.svg', 'template.svg', 'overlay-template.svg']
  install_data (file,
                install_dir: join_paths(pkgdata_dir, 'themes')
  )
endforeach

# Icons
foreach size: [ '16x16', '22x22', '24x24', '32x32', '48x48', '256x256', '512x512' ]
    install_data(join_paths('icons', 'hicolor', size, 'org.gnome.five-or-more.png'),
                 install_dir: join_paths (data_dir, 'icons', 'hicolor', size, 'apps')
    )
endforeach

install_data (join_paths ('icons', 'hicolor', 'symbolic', 'org.gnome.five-or-more-symbolic.svg'),
             install_dir: join_paths (data_dir, 'icons', 'hicolor', 'symbolic', 'apps')
             )

# Make D-Bus activatable
service_conf = configuration_data ()
service_conf.set ('bindir', bindir)

service = 'org.gnome.five-or-more.service'

configure_file (
  input: service + '.in',
  output: service,
  install: true,
  install_dir: join_paths (data_dir, 'dbus-1', 'services'),
  configuration: service_conf
)

# metainfo
metainfo = 'org.gnome.five-or-more.metainfo.xml'
metainfo_file = i18n.merge_file (
  input: metainfo + '.in',
  output: metainfo,
  type: 'xml',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths (data_dir, 'metainfo'),
)
appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test(
    'validate-metainfo', appstreamcli,
    args: [
      'validate', '--no-net', '--explain', metainfo_file.full_path()
    ]
  )
endif

# Gschema
install_data ('org.gnome.five-or-more.gschema.xml',
  install_dir: join_paths (data_dir, 'glib-2.0', 'schemas')
)

# Gresource
resource_files = files ('org.gnome.five-or-more.gresource.xml')

# Generate fallback resources if needed
fallback_generator = find_program(join_paths(meson.project_source_root(), 'tools', 'generate-fallback-resources.py'), required: false)
if fallback_generator.found()
  run_command(
    fallback_generator,
    '--data-dir', meson.current_source_dir(),
    '--output-dir', meson.current_build_dir(),
    '--gresource-file', files('org.gnome.five-or-more.gresource.xml')[0],
    '--generate-checksums',
    check: false
  )
endif

resources = gnome.compile_resources ('five-or-more', resource_files)

# Sample configuration file
install_data ('game-constants.conf.sample',
  install_dir: join_paths (data_dir, 'five-or-more', 'examples')
)

# Manpage
install_man (
  'five-or-more.6'
)
