// #include <gtk/gtk.h>
#include "net_tools.c"
#include "/home/franklin/workspace/lab-franklin/src/gui-test/include/lab_common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__)
#include <netdb.h>
#include <netinet/in.h> 
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <unistd.h>

#elif defined(_WIN32)
#include <winsock2.h>
#include <ws2tcpip.h>
#endif



int ping_host(char ip_address[100]);

int main() {
  char ip_address[100] = "8.8.8.8";
  status = ping_host(ip_address);
  printf("STATUS: %d\n", status);
  status2 = hostname_and_ip();
  return status;
}




/*
void greet(GtkWidget *widget, gpointer data) {
  // printf equivalent in GTK+
  g_print("Welcome to GTK\n");
  g_print("%s clicked %d times\n", (char *)data, ++counter);
}

void destroy(GtkWidget *widget, gpointer data) { gtk_main_quit(); }

int main(int argc, char *argv[]) {
  GtkWidget *window;
  GtkWidget *button;
  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

  g_signal_connect(window, "destroy", G_CALLBACK(destroy), NULL);
  gtk_container_set_border_width(GTK_CONTAINER(window), 20); // last num is
border width

  button = gtk_button_new_with_label("Click Me!");

  g_signal_connect(GTK_OBJECT(button), "clicked", G_CALLBACK(greet), "button");

  gtk_container_add(GTK_CONTAINER(window), button);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}

static void activate (GtkApplication* app, gpointer user_data)
{
  GtkWidget *window;

  window = gtk_application_window_new (app);
  gtk_window_set_title (GTK_WINDOW (window), "Window");
  gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);
  gtk_widget_show_all (window);
}

int main (int argc, char **argv)
{
  GtkApplication *app;
  int status;

  app = gtk_application_new ("org.gtk.example", G_APPLICATION_FLAGS_NONE);
  g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
  status = g_application_run (G_APPLICATION (app), argc, argv);
  g_object_unref (app);

  return status;
}
*/
