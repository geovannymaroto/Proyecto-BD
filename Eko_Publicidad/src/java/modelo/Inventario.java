package modelo;

public class Inventario {
    String sku;
    String descripcion;
    String es_combo;
    int unidades_disponibles;
    int valor_total;
    
    public Inventario(){
        
    }

    public Inventario(String sku, String descripcion, String es_combo, int unidades_disponibles, int valor_total) {
        this.sku = sku;
        this.descripcion = descripcion;
        this.es_combo = es_combo;
        this.unidades_disponibles = unidades_disponibles;
        this.valor_total = valor_total;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getEs_combo() {
        return es_combo;
    }

    public void setEs_combo(String es_combo) {
        this.es_combo = es_combo;
    }

    public int getUnidades_disponibles() {
        return unidades_disponibles;
    }

    public void setUnidades_disponibles(int unidades_disponibles) {
        this.unidades_disponibles = unidades_disponibles;
    }

    public int getValor_total() {
        return valor_total;
    }

    public void setValor_total(int valor_total) {
        this.valor_total = valor_total;
    }

    
    
    
}
