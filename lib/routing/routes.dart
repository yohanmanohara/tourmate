const rootRoute = "/";

const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/login";

const driversPageDisplayName = "Camera";
const driversPageRoute = "/camera";

const clientsPageDisplayName = "Clients";
const clientsPageRoute = "/client";

const authenticationPageDisplayName = "Log out";
const authenticationPageRoute = "/aut";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}



List<MenuItem> sideMenuItemRoutes = [
 MenuItem(overviewPageDisplayName, overviewPageRoute),
 MenuItem(driversPageDisplayName, driversPageRoute),
 MenuItem(clientsPageDisplayName, clientsPageRoute),
 MenuItem(authenticationPageDisplayName, authenticationPageRoute),
];
