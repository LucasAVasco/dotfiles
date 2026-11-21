#include <gio/gio.h>

#include <cstring>

namespace {

constexpr char BUS_NAME[] = "org.freedesktop.FileManager1";
constexpr char OBJECT_PATH[] = "/org/freedesktop/FileManager1";

GMainLoop *main_loop = nullptr;
GDBusNodeInfo *introspection_data = nullptr;
guint object_registration_id = 0;

constexpr char INTROSPECTION_XML[] = R"(
<node>
    <interface name="org.freedesktop.FileManager1">
        <method name="ShowFolders">
            <arg type="as" direction="in"/>
            <arg type="s" direction="in"/>
        </method>
        <method name="ShowItems">
            <arg type="as" direction="in"/>
            <arg type="s" direction="in"/>
        </method>
        <method name="ShowItemProperties">
            <arg type="as" direction="in"/>
            <arg type="s" direction="in"/>
        </method>
    </interface>
</node>
)";

// Convert a file URI into a filesystem path.
gchar *uri_to_path(const gchar *uri) {
  const gchar *scheme = g_uri_peek_scheme(uri);

  if (scheme == nullptr || g_ascii_strcasecmp(scheme, "file") != 0) {
    return g_strdup(uri);
  }

  GError *error = nullptr;
  GUri *parsed = g_uri_parse(uri, G_URI_FLAGS_NONE, &error);

  if (parsed == nullptr) {
    g_warning("Failed to parse URI '%s': %s", uri, error->message);
    g_clear_error(&error);
    return g_strdup(uri);
  }

  const gchar *encoded_path = g_uri_get_path(parsed);
  gchar *path = g_uri_unescape_string(
      encoded_path != nullptr ? encoded_path : "", nullptr);

  g_uri_unref(parsed);

  return path != nullptr ? path : g_strdup(uri);
}

// Open a location using `default_file_manager`.
void open_uri(const gchar *uri, bool open_parent) {
  gchar *path = uri_to_path(uri);

  gchar *argv[] = {const_cast<gchar *>(open_parent ? "default_file_manager"
                                                   : "default_open"),
                   path, nullptr};

  GError *error = nullptr;

  if (!g_spawn_async(nullptr, argv, nullptr, G_SPAWN_SEARCH_PATH, nullptr,
                     nullptr, nullptr, &error)) {
    g_warning("Failed to launch file opener for '%s': %s", path,
              error->message);
    g_clear_error(&error);
  }

  g_free(path);
}

// Handle FileManager1 D-Bus method calls.
void handle_method_call(GDBusConnection *connection, const gchar *sender,
                        const gchar *object_path, const gchar *interface_name,
                        const gchar *method_name, GVariant *parameters,
                        GDBusMethodInvocation *invocation, gpointer user_data) {
  (void)connection;
  (void)sender;
  (void)object_path;
  (void)interface_name;
  (void)user_data;

  GVariant *uris = nullptr;
  const gchar *startup_id = nullptr;

  g_variant_get(parameters, "(@as&s)", &uris, &startup_id);
  (void)startup_id;

  const bool open_parent = std::strcmp(method_name, "ShowFolders") != 0;

  GVariantIter iter;
  g_variant_iter_init(&iter, uris);

  const gchar *uri = nullptr;

  while (g_variant_iter_next(&iter, "&s", &uri)) {
    open_uri(uri, open_parent);
  }

  g_variant_unref(uris);

  g_dbus_method_invocation_return_value(invocation, g_variant_new("()"));
}

// D-Bus interface callbacks.
const GDBusInterfaceVTable interface_vtable = {
    handle_method_call, nullptr, nullptr, {nullptr}};

// Called when the session bus connection becomes available.
void on_bus_acquired(GDBusConnection *connection, const gchar *name,
                     gpointer user_data) {
  (void)name;
  (void)user_data;

  GError *error = nullptr;

  object_registration_id = g_dbus_connection_register_object(
      connection, OBJECT_PATH, introspection_data->interfaces[0],
      &interface_vtable, nullptr, nullptr, &error);

  if (object_registration_id == 0) {
    g_warning("Failed to register D-Bus object: %s", error->message);
    g_clear_error(&error);
    g_main_loop_quit(main_loop);
  }
}

// Called when the service successfully acquires its bus name.
void on_name_acquired(GDBusConnection *connection, const gchar *name,
                      gpointer user_data) {
  (void)connection;
  (void)user_data;

  g_message("D-Bus service '%s' is running.", name);
}

// Called when the service loses the bus name.
void on_name_lost(GDBusConnection *connection, const gchar *name,
                  gpointer user_data) {
  (void)connection;
  (void)user_data;

  g_warning("Lost D-Bus service name: %s", name);

  g_main_loop_quit(main_loop);
}

} // namespace

int main() {
  GError *error = nullptr;

  introspection_data = g_dbus_node_info_new_for_xml(INTROSPECTION_XML, &error);

  if (introspection_data == nullptr) {
    g_printerr("Failed to parse D-Bus interface: %s\n", error->message);
    g_clear_error(&error);
    return 1;
  }

  main_loop = g_main_loop_new(nullptr, FALSE);

  const guint owner_id = g_bus_own_name(
      G_BUS_TYPE_SESSION, BUS_NAME, G_BUS_NAME_OWNER_FLAGS_NONE,
      on_bus_acquired, on_name_acquired, on_name_lost, nullptr, nullptr);

  g_main_loop_run(main_loop);

  g_bus_unown_name(owner_id);

  if (object_registration_id != 0) {
    // The connection is released when the bus owner is removed.
    object_registration_id = 0;
  }

  g_main_loop_unref(main_loop);
  g_dbus_node_info_unref(introspection_data);

  return 0;
}
