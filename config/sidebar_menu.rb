SIDEBAR_MENU = [
  {
    section: "Principal",
    items: [
      {
        label: "Dashboard",
        path: :authenticated_root_path,
        icon: "dashboard",
        active: { controller: ["dashboard"] }
      }
    ]
  },

  {
    section: "Operaciones",
    module: :billing,
    items: [
      {
        label: "Facturas",
        path: :invoices_path,
        icon: "invoice",
        active: { controller: ["invoices"] }
      },
      {
        label: "Clientes",
        path: :customers_path,
        icon: "customers",
        active: { controller: ["customers"] }
      }
    ]
  },

  {
    section: "POS",
    module: :pos,
    items: [
      {
        label: "POS Restaurante",
        path: :pos_index_path,
        icon: "pos",
        active: { controller: ["pos"] }
      },
      {
        label: "Historial Comandas",
        path: :history_orders_path,
        icon: "history",
        active: { controller: ["orders"] }
      }
    ]
  },

  {
    section: "Gestión Académica",
    module: :academic,
    items: [
      { label: "Estudiantes", path: :students_path, icon: "students", active: { controller: ["students"] } },
      { label: "Instructores", path: :trainers_path, icon: "trainers", active: { controller: ["trainers"] } }
    ]
  }
]
