const rootRoute = "/";

const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/login";


const arPageDisplayName = "AR_Capture musium";
const arPageRoute = "/AR";


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
 MenuItem(arPageDisplayName, arPageRoute),
 MenuItem(clientsPageDisplayName, clientsPageRoute),
 MenuItem(authenticationPageDisplayName, authenticationPageRoute),
];
