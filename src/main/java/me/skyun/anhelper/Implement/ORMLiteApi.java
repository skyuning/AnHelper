package me.skyun.anhelper.Implement;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.RuntimeExceptionDao;

import java.sql.SQLException;
import java.util.Collection;
import java.util.List;

import me.skyun.anhelper.Interface.IORMApi;

/**
 * Created by linyun on 15-6-1.
 */
public class ORMLiteApi implements IORMApi {

    private OrmLiteSqliteOpenHelper mDBHelper;

    public ORMLiteApi(OrmLiteSqliteOpenHelper DBHelper) {
        mDBHelper = DBHelper;
    }

    @Override
    public <T> void insertIfNotExists(T item) {
        getDao(item).createIfNotExists(item);
    }

    @Override
    public <T, ID> T queryForId(Class<T> clz, ID id) {
        return getDao(clz, id).queryForId(id);
    }

    @Override
    public <T> List<T> queryAll(Class<T> clz) {
        return getDao(clz).queryForAll();
    }

    @Override
    public <T> int delete(T item) {
        return getDao(item).delete(item);
    }

    public <T> int delete(Collection<T> items) {
        if (items.isEmpty())
            return 0;
        return getDao(items.iterator().next()).delete(items);
    }

    @Override
    public void beginTransaction() throws SQLException {
        mDBHelper.getConnectionSource().getReadWriteConnection().setSavePoint(null);
    }

    @Override
    public void commit() throws SQLException {
        mDBHelper.getConnectionSource().getReadWriteConnection().commit(null);
    }

    @Override
    public void rollback() throws SQLException {
        mDBHelper.getConnectionSource().getReadWriteConnection().rollback(null);
    }

    /**
     * methods to get DAO
     */
    private <T, ID> RuntimeExceptionDao<T, ID> getDao(Class<T> clz, ID id) {
        return mDBHelper.getRuntimeExceptionDao(clz);
    }

    private <T> RuntimeExceptionDao<T, ?> getDao(Class<T> clz) {
        return mDBHelper.getRuntimeExceptionDao(clz);
    }

    private <T> RuntimeExceptionDao<T, ?> getDao(T item) {
        return mDBHelper.getRuntimeExceptionDao((Class<T>) item.getClass());
    }
}

