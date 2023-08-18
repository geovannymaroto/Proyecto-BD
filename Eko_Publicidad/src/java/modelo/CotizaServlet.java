/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.io.IOException;
import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.util.logging.Level;
import java.util.logging.Logger;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author LuisK
 */
@WebServlet("/CotizaServlet")
public class CotizaServlet extends HttpServlet{

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
         
//        Connection con;
//        Conexion cn = new Conexion();
        
        // Leer campos del form de "ingresoCotizacion.html"
        String idProveedor = request.getParameter("idProveedor");
        String sku = request.getParameter("sku");
        String fechaCotiza = request.getParameter("fechaCotiza");
        String fechaVence = request.getParameter("fechaVence");
        
//        con = cn.getConnection();
        String url = "jdbc:oracle:thin:@localhost:1521:orcl";
        String user = "DBAPROY";
        String pass = "dba24680";
        
        String orden = "{call DBAPROY.nuevaCotizacion(?,?,?,?)}";
        CallableStatement cstmt;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(url,user,pass);
                        
            cstmt = con.prepareCall(orden);
            cstmt.setString(1, idProveedor);
            cstmt.setString(2, sku);
            cstmt.setString(3, fechaCotiza);
            cstmt.setString(4, fechaVence);
            
            cstmt.execute();
            cstmt.close();
            
        } catch (SQLException | ClassNotFoundException
                ex) {            
            Logger.getLogger(CotizaServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        
}
}
