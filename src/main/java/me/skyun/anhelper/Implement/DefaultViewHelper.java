package me.skyun.anhelper.Implement;

import android.app.Activity;
import android.view.View;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Map;

import me.skyun.anhelper.Interface.IViewHelper;

/**
 * Created by linyun on 15-5-28.
 */
public class DefaultViewHelper implements IViewHelper {

    private Map<Integer, View> mViewMap = new HashMap<Integer, View>();
    private Activity mActivity;

    public DefaultViewHelper(Activity activity) {
        mActivity = activity;
    }

    private View findView(View parent, int id) {
        View view = mViewMap.get(id);
        if (view == null) {
            view = parent.findViewById(id);
            mViewMap.put(id, view);
        }
        return view;
    }

    public void render(Object... objects) {
        render(mActivity.getWindow().getDecorView(), objects);
    }

    public void render(View parent, Object... objects) {
        for (int i = 0; i < objects.length; i += 2) {
            // get view from map, or set view to map
            Integer id = (Integer) objects[i];
            View view = findView(parent, id);

            Object obj = objects[i + 1];

            if (obj instanceof View.OnClickListener) {
                view.setOnClickListener((View.OnClickListener) obj);
                continue;
            }

            // render according view type
            if (view instanceof TextView) {
                String text = (String) objects[i + 1];
                ((TextView) view).setText(text);
            }
        }
    }

    public String getText(int id) {
        TextView view = (TextView) findView(mActivity.getWindow().getDecorView(), id);
        return view.getText().toString();
    }
}
