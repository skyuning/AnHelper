package me.skyun.anhelper.Interface;

import java.sql.SQLException;
import java.util.Collection;
import java.util.List;

/**
 * Created by linyun on 15-6-1.
 */
public interface IORMApi {

    public <T> void insertIfNotExists(T item);

    public <T, ID> T queryForId(Class<T> clz, ID id);

    public <T> List<T> queryAll(Class<T> clz);

    public <T> int delete(T item);

    public <T> int delete(Collection<T> items);

    public void beginTransaction() throws SQLException;

    public void commit() throws SQLException;

    public void rollback() throws SQLException;
}
