/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author 50660
 */
public class UsuarioDAO { //implements validar

    Connection con;
    Conexion cn = new Conexion();
    PreparedStatement ps;
    ResultSet rs;
    int r = 0;
    Usuario user;

    public int validar() {
    String sql = "select * from usuarios where CED=? and CONTRASENHA=?";
        try {
            
                con = cn.getConnection();
                ps = con.prepareStatement(sql);
//                ps.setString(1, rs.getString("cedula"));
//                ps.setString(2, rs.getString("contrasena"));
                ps.setString(1, user.getCedula());
                ps.setString(2, user.getContrasena());
                rs = ps.executeQuery();

            //while (rs.next()) {
            if (rs.next() == true) {
                //r = r + 1;
                //user.setCedula(rs.getString("cedula"));
                //user.setContrasena(rs.getString("contrasena"));
                r = 1;
            
//            if(r==1){
//               return 1;
            
            }else{
                r = 0;
            }
            
        }catch (Exception e) {
        }
        return r;
    }
}
