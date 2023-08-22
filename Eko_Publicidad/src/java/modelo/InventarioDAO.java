package modelo;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.lang.model.util.Types;
import oracle.jdbc.OracleTypes;

public class InventarioDAO {    
    Conexion1 c = new Conexion1();
    Connection con;
    ResultSet rs;
    
    public List listar(){
        List<Inventario>lista=new ArrayList<>();
        String sql = "{call mostrarInventario.mostrarInventarioVista(?,?,?,?,?)}";
        CallableStatement cstmt;
        try{
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con=c.conectar();
            cstmt = con.prepareCall(sql);
//            OracleTypes / java.sql.Types
            cstmt.registerOutParameter(1, OracleTypes.VARCHAR); 
            cstmt.registerOutParameter(2, OracleTypes.VARCHAR);
            cstmt.registerOutParameter(3, OracleTypes.VARCHAR);
            cstmt.registerOutParameter(4, OracleTypes.NUMERIC);
            cstmt.registerOutParameter(5, OracleTypes.NUMERIC);
            rs=cstmt.executeQuery();
            while(rs.next()){
                Inventario i = new Inventario();
                i.setSku(cstmt.getString(1));
                i.setDescripcion(cstmt.getString(2));
                i.setEs_combo(cstmt.getString(3));
                i.setUnidades_disponibles(cstmt.getInt(4));
                i.setValor_total(cstmt.getInt(5));
                lista.add(i);
            }
            cstmt.close();
        }catch(Exception e){
        }
        return lista;
    }
}
