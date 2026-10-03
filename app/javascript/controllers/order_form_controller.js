import { Controller } from "@hotwired/stimulus"

// Formulario dinámico de pedidos (joyería):
// - Agrega / quita piezas (nested attributes)
// - Cascada producto → variantes (JSON) y precio sugerido
// - Totales en vivo
// - Campos de personalización según el tipo de pedido (vitrina / taller)
export default class extends Controller {
  static targets = ["items", "item", "template", "kind", "total", "totalItems", "balance",
                    "emptyState", "workshopSection", "dateRequired", "dateHint"]
  static values = { variantsUrl: String, advance: Number, currency: String }

  connect() {
    this.formatter = new Intl.NumberFormat("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    this.itemTargets.forEach((row) => this.applyCustomVisibility(row))
    this.kindChanged()
    this.recalculate()
  }

  // ---------------------------------------------------------------- Items
  addItem(event) {
    event?.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, `${Date.now()}${Math.floor(Math.random() * 1000)}`)
    this.itemsTarget.insertAdjacentHTML("beforeend", html)

    const row = this.itemsTarget.lastElementChild
    this.applyCustomVisibility(row)
    row.classList.add("animate-pulse")
    setTimeout(() => row.classList.remove("animate-pulse"), 400)
    row.scrollIntoView({ behavior: "smooth", block: "nearest" })
    this.recalculate()
  }

  removeItem(event) {
    const row = event.currentTarget.closest("[data-order-form-target='item']")
    if (!row) return

    if (row.dataset.newRecord === "true") {
      row.remove()
    } else {
      row.querySelector("[data-role='destroy']").value = "1"
      row.classList.add("hidden")
      row.dataset.removed = "true"
    }
    this.recalculate()
  }

  // ------------------------------------------------- Producto → variantes
  async productChanged(event) {
    const row = event.currentTarget.closest("[data-order-form-target='item']")
    const productId = event.currentTarget.value
    const variantSelect = row.querySelector("[data-role='variant']")
    const priceInput = row.querySelector("[data-role='price']")

    this.renderVariantMeta(row, null)
    variantSelect.innerHTML = ""

    if (!productId) {
      variantSelect.append(new Option("Primero elige una pieza", ""))
      variantSelect.disabled = true
      this.recalculate()
      return
    }

    variantSelect.append(new Option("Cargando variantes…", ""))
    variantSelect.disabled = true

    try {
      const url = this.variantsUrlValue.replace("__PRODUCT__", encodeURIComponent(productId))
      const response = await fetch(url, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const data = await response.json()

      variantSelect.innerHTML = ""
      const placeholder = data.variants.length ? "Sin variante específica" : "Este producto no tiene variantes"
      variantSelect.append(new Option(placeholder, ""))

      data.variants.forEach((variant) => {
        const option = new Option(variant.label, variant.id)
        option.dataset.price = variant.price
        option.dataset.metal = variant.metal_type || ""
        option.dataset.karat = variant.karat || ""
        option.dataset.size = variant.size || ""
        option.dataset.weight = variant.weight_grams || ""
        variantSelect.append(option)
      })

      variantSelect.disabled = data.variants.length === 0
      priceInput.value = Number(data.product.price || 0).toFixed(2)

      // Si solo hay una variante, se preselecciona.
      if (data.variants.length === 1) {
        variantSelect.value = data.variants[0].id
        this.applyVariant(row, variantSelect.selectedOptions[0])
      }
    } catch (error) {
      console.error("Error cargando variantes", error)
      variantSelect.innerHTML = ""
      variantSelect.append(new Option("No se pudieron cargar las variantes", ""))
    }

    this.recalculate()
  }

  variantChanged(event) {
    const row = event.currentTarget.closest("[data-order-form-target='item']")
    this.applyVariant(row, event.currentTarget.selectedOptions[0])
    this.recalculate()
  }

  applyVariant(row, option) {
    if (option && option.value) {
      row.querySelector("[data-role='price']").value = Number(option.dataset.price || 0).toFixed(2)
      this.renderVariantMeta(row, option.dataset)
    } else {
      this.renderVariantMeta(row, null)
    }
  }

  renderVariantMeta(row, data) {
    const container = row.querySelector("[data-role='variant-meta']")
    container.innerHTML = ""
    if (!data) return

    const chips = {
      Metal: data.metal,
      Kilataje: data.karat ? data.karat.toUpperCase() : "",
      Talla: data.size,
      Peso: Number(data.weight) > 0 ? `${Number(data.weight)} g` : ""
    }

    Object.entries(chips).forEach(([label, value]) => {
      if (!value) return
      const chip = document.createElement("span")
      chip.className = "rounded-lg bg-amber-50 px-2 py-1 text-[11px] font-semibold text-amber-800 ring-1 ring-inset ring-amber-100"
      chip.textContent = `${label}: ${value}`
      container.append(chip)
    })
  }

  // ------------------------------------------------------- Personalización
  kindChanged() {
    const isCustom = this.isCustomOrder
    this.itemTargets.forEach((row) => this.applyCustomVisibility(row))

    if (this.hasDateRequiredTarget) this.dateRequiredTarget.classList.toggle("hidden", !isCustom)
    if (this.hasDateHintTarget) {
      this.dateHintTarget.textContent = isCustom
        ? "Obligatoria para encargos de taller."
        : "Opcional en ventas de vitrina (apartados)."
    }
    if (this.hasWorkshopSectionTarget) {
      this.workshopSectionTarget.classList.toggle("ring-2", isCustom)
      this.workshopSectionTarget.classList.toggle("ring-amber-200", isCustom)
    }
  }

  toggleCustom(event) {
    const row = event.currentTarget.closest("[data-order-form-target='item']")
    row.dataset.customOpen = row.dataset.customOpen === "true" ? "false" : "true"
    this.setCustomVisible(row, row.dataset.customOpen === "true")
  }

  // Taller: siempre visible. Vitrina: visible solo si ya tiene datos o el usuario lo abrió.
  applyCustomVisibility(row) {
    const hasData = row.dataset.customized === "true"
    const manuallyOpen = row.dataset.customOpen === "true"
    this.setCustomVisible(row, this.isCustomOrder || hasData || manuallyOpen)
  }

  setCustomVisible(row, visible) {
    const block = row.querySelector("[data-role='custom']")
    const label = row.querySelector("[data-role='custom-toggle-label']")
    block.classList.toggle("hidden", !visible)
    block.classList.toggle("grid", visible)
    if (label) label.textContent = visible ? "Ocultar personalización" : "Grabado y especificaciones"
    row.dataset.customOpen = visible ? "true" : "false"
  }

  get isCustomOrder() {
    const checked = this.kindTargets.find((input) => input.checked)
    return checked?.value === "custom_order"
  }

  // ---------------------------------------------------------------- Totales
  recalculate() {
    let total = 0
    let pieces = 0
    const activeRows = this.itemTargets.filter((row) => row.dataset.removed !== "true")

    activeRows.forEach((row) => {
      const qty = parseFloat(row.querySelector("[data-role='quantity']").value) || 0
      const price = parseFloat(row.querySelector("[data-role='price']").value) || 0
      const subtotal = qty * price
      row.querySelector("[data-role='subtotal']").textContent = this.money(subtotal)
      total += subtotal
      pieces += qty
    })

    if (this.hasTotalTarget) this.totalTarget.textContent = this.money(total)
    if (this.hasTotalItemsTarget) this.totalItemsTarget.textContent = Math.round(pieces)
    if (this.hasBalanceTarget) this.balanceTarget.textContent = this.money(total - this.advanceValue)
    if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.toggle("hidden", activeRows.length > 0)
  }

  money(amount) {
    return `${this.currencyValue} ${this.formatter.format(amount)}`
  }
}
